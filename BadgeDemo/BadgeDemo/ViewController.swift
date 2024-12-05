import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    var contador = 0
    var productos: [String: Int] = [:] // Diccionario para rastrear productos y cantidades
    var carruselImages = ["iPhoneSilver", "iPhoneGris", "iPhoneXs", "iPhoneGlass"]
    var previsualizacionImageView: UIImageView!
    var detallesLabel: UILabel! // UILabel para mostrar detalles del producto
    var imagenSeleccionada: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setupCarrusel()
        setupPrevisualizacion()
        self.addBadge(itemvalue: "0")
    }

    // MARK: - Métodos de gestión del carrito y la bolsa

    func addBadge(itemvalue: String) {
        let bagButton = BadgeButton()
        bagButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        bagButton.tintColor = UIColor.darkGray
        bagButton.setImage(UIImage(named: "bag.png")?.withRenderingMode(.alwaysTemplate), for: .normal)
        bagButton.badgeEdgeInsets = UIEdgeInsets(top: 18, left: 8, bottom: 0, right: 15)
        bagButton.badge = itemvalue
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: bagButton)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        bagButton.addGestureRecognizer(tapGestureRecognizer)
    }

    @IBAction func incrementa(_ sender: Any) {
        guard let seleccion = imagenSeleccionada else {
            let alertController = UIAlertController(
                title: "Error",
                message: "Por favor selecciona un producto antes de agregarlo al carrito.",
                preferredStyle: .alert
            )
            alertController.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }

        if let cantidad = productos[seleccion] {
            productos[seleccion] = cantidad + 1
        } else {
            productos[seleccion] = 1
        }
        contador += 1

        self.addBadge(itemvalue: String(contador))
    }
    
    @IBAction func decrementa(_ sender: Any) {
        guard let seleccion = imagenSeleccionada else {
            let alertController = UIAlertController(
                title: "Error",
                message: "Por favor selecciona un producto antes de disminuir su cantidad en el carrito.",
                preferredStyle: .alert
            )
            alertController.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }

        if let cantidad = productos[seleccion], cantidad > 0 {
            if cantidad == 1 {
                productos.removeValue(forKey: seleccion)
            } else {
                productos[seleccion] = cantidad - 1
            }
            contador -= 1
        } else {
            let alertController = UIAlertController(
                title: "Error",
                message: "Este producto no está en el carrito.",
                preferredStyle: .alert
            )
            alertController.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }

        contador = max(0, contador)
        self.addBadge(itemvalue: String(contador))
    }

    @IBAction func comprar(_ sender: Any) {
        guard !productos.isEmpty else {
            let alertController = UIAlertController(
                title: "Carrito vacío",
                message: "No puedes realizar una compra sin productos en el carrito.",
                preferredStyle: .alert
            )
            alertController.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }

        let alertController = UIAlertController(
            title: "Compra realizada",
            message: "¡Gracias por tu compra!",
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)

        limpiarCarrito()
    }

    @objc func didTap(_ sender: UITapGestureRecognizer) {
        mostrarListaDeProductos()
    }

    func mostrarListaDeProductos() {
        let mensaje = productos.isEmpty
            ? "No hay productos en la bolsa."
            : productos.map { "\($0.key): \($0.value)" }.joined(separator: "\n")

        let alertController = UIAlertController(
            title: "Productos en la bolsa",
            message: mensaje,
            preferredStyle: .alert
        )

        let cerrarAction = UIAlertAction(title: "Cerrar", style: .cancel, handler: nil)
        alertController.addAction(cerrarAction)

        let limpiarAction = UIAlertAction(title: "Limpiar carrito", style: .destructive) { _ in
            self.limpiarCarrito()
        }
        alertController.addAction(limpiarAction)

        self.present(alertController, animated: true, completion: nil)
    }

    func limpiarCarrito() {
        productos.removeAll()
        contador = 0
        self.addBadge(itemvalue: "0")
        
        let alertController = UIAlertController(
            title: "Carrito vacío",
            message: "Tu carrito ha sido limpiado.",
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

    // MARK: - Configuración del carrusel de imágenes

    func setupCarrusel() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.minimumLineSpacing = 10

        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 100, width: self.view.bounds.width, height: 120), collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "carruselCell")
        collectionView.backgroundColor = .clear

        self.view.addSubview(collectionView)
    }

    // MARK: - Configuración de la previsualización de producto

    func setupPrevisualizacion() {
        previsualizacionImageView = UIImageView()
        previsualizacionImageView.translatesAutoresizingMaskIntoConstraints = false
        previsualizacionImageView.contentMode = .scaleAspectFit
        previsualizacionImageView.layer.cornerRadius = 10
        previsualizacionImageView.clipsToBounds = true
        previsualizacionImageView.isHidden = true
        self.view.addSubview(previsualizacionImageView)
       
        NSLayoutConstraint.activate([
            previsualizacionImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            previsualizacionImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 250),
            previsualizacionImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            previsualizacionImageView.heightAnchor.constraint(equalToConstant: 300)
        ])
       
        detallesLabel = UILabel()
        detallesLabel.translatesAutoresizingMaskIntoConstraints = false
        detallesLabel.textAlignment = .center
        detallesLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        detallesLabel.textColor = .darkGray
        detallesLabel.numberOfLines = 0
        detallesLabel.isHidden = true
        self.view.addSubview(detallesLabel)
       
        NSLayoutConstraint.activate([
            detallesLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            detallesLabel.topAnchor.constraint(equalTo: previsualizacionImageView.bottomAnchor, constant: 16),
            detallesLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8)
        ])
    }

    // MARK: - Métodos de UICollectionView DataSource y Delegate

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return carruselImages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "carruselCell", for: indexPath)
        cell.backgroundColor = .clear

        let imageView = UIImageView(frame: cell.contentView.bounds)
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: carruselImages[indexPath.item])
        cell.contentView.addSubview(imageView)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedImage = carruselImages[indexPath.item]
        imagenSeleccionada = selectedImage

        previsualizacionImageView.image = UIImage(named: selectedImage)
        previsualizacionImageView.isHidden = false
       
        detallesLabel.text = obtenerDetallesProducto(para: selectedImage)
        detallesLabel.isHidden = false
    }

    // MARK: - Obtención de detalles del producto

    func obtenerDetallesProducto(para producto: String) -> String {
        switch producto {
        case "iPhoneSilver":
            return "iPhone Silver: Memoria 128GB, Cámara 12MP, Pantalla Retina. Precio: $19,999 MXN"
        case "iPhoneGris":
            return "iPhone Gris: Memoria 256GB, Cámara 12MP, Pantalla Retina HD. Precio: $22,499 MXN"
        case "iPhoneXs":
            return "iPhone Xs: Memoria 64GB, Cámara 12MP, Edición Especial. Precio: $24,999 MXN"
        case "iPhoneGlass":
            return "iPhone Glass: Resistente a rayones. Precio: $399 MXN"
        default:
            return "Detalles no disponibles para este producto."
        }
    }

}

